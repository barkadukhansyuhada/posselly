import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/template_model.dart';
import '../../models/product_model.dart';
import '../../models/invoice_model.dart';

abstract class SqliteDatasource {
  Future<void> initDatabase();
  
  // Templates
  Future<List<TemplateModel>> getTemplates();
  Future<List<TemplateModel>> getTemplatesByCategory(String category);
  Future<void> cacheTemplates(List<TemplateModel> templates);
  Future<void> insertTemplate(TemplateModel template);
  Future<void> updateTemplate(TemplateModel template);
  Future<void> deleteTemplate(String id);
  Future<void> incrementTemplateUsage(String id);
  
  // Products
  Future<List<ProductModel>> getProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> insertProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
  
  // Invoices
  Future<List<InvoiceModel>> getInvoices();
  Future<void> cacheInvoices(List<InvoiceModel> invoices);
  Future<void> insertInvoice(InvoiceModel invoice);
  Future<void> updateInvoice(InvoiceModel invoice);
  Future<void> deleteInvoice(String id);
}

class SqliteDatasourceImpl implements SqliteDatasource {
  Database? _database;

  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  @override
  Future<Database> initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConfig.localDbName);

      return await openDatabase(
        path,
        version: AppConfig.localDbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw CacheException('Failed to initialize database: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE templates (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        usage_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        invoice_number TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT,
        items TEXT NOT NULL,
        subtotal REAL NOT NULL,
        shipping_cost REAL DEFAULT 0,
        total REAL NOT NULL,
        pdf_url TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_templates_category ON templates(category);
    ''');

    await db.execute('''
      CREATE INDEX idx_templates_usage ON templates(usage_count DESC);
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
  }

  // Templates
  @override
  Future<List<TemplateModel>> getTemplates() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'templates',
        orderBy: 'usage_count DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return TemplateModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException('Failed to get templates: $e');
    }
  }

  @override
  Future<List<TemplateModel>> getTemplatesByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'templates',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'usage_count DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return TemplateModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException('Failed to get templates by category: $e');
    }
  }

  @override
  Future<void> cacheTemplates(List<TemplateModel> templates) async {
    try {
      final db = await database;
      final batch = db.batch();

      // Clear existing templates
      batch.delete('templates');

      // Insert new templates
      for (final template in templates) {
        batch.insert('templates', template.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw CacheException('Failed to cache templates: $e');
    }
  }

  @override
  Future<void> insertTemplate(TemplateModel template) async {
    try {
      final db = await database;
      await db.insert(
        'templates',
        template.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to insert template: $e');
    }
  }

  @override
  Future<void> updateTemplate(TemplateModel template) async {
    try {
      final db = await database;
      await db.update(
        'templates',
        template.toJson(),
        where: 'id = ?',
        whereArgs: [template.id],
      );
    } catch (e) {
      throw CacheException('Failed to update template: $e');
    }
  }

  @override
  Future<void> deleteTemplate(String id) async {
    try {
      final db = await database;
      await db.delete(
        'templates',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to delete template: $e');
    }
  }

  @override
  Future<void> incrementTemplateUsage(String id) async {
    try {
      final db = await database;
      await db.rawUpdate(
        'UPDATE templates SET usage_count = usage_count + 1 WHERE id = ?',
        [id],
      );
    } catch (e) {
      throw CacheException('Failed to increment template usage: $e');
    }
  }

  // Products (placeholder implementations)
  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return ProductModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException('Failed to get products: $e');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final db = await database;
      final batch = db.batch();

      batch.delete('products');
      for (final product in products) {
        batch.insert('products', product.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw CacheException('Failed to cache products: $e');
    }
  }

  @override
  Future<void> insertProduct(ProductModel product) async {
    try {
      final db = await database;
      await db.insert(
        'products',
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to insert product: $e');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      final db = await database;
      await db.update(
        'products',
        product.toJson(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw CacheException('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final db = await database;
      await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to delete product: $e');
    }
  }

  // Invoices (placeholder implementations)
  @override
  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'invoices',
        orderBy: 'created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return InvoiceModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw CacheException('Failed to get invoices: $e');
    }
  }

  @override
  Future<void> cacheInvoices(List<InvoiceModel> invoices) async {
    try {
      final db = await database;
      final batch = db.batch();

      batch.delete('invoices');
      for (final invoice in invoices) {
        batch.insert('invoices', invoice.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw CacheException('Failed to cache invoices: $e');
    }
  }

  @override
  Future<void> insertInvoice(InvoiceModel invoice) async {
    try {
      final db = await database;
      await db.insert(
        'invoices',
        invoice.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to insert invoice: $e');
    }
  }

  @override
  Future<void> updateInvoice(InvoiceModel invoice) async {
    try {
      final db = await database;
      await db.update(
        'invoices',
        invoice.toJson(),
        where: 'id = ?',
        whereArgs: [invoice.id],
      );
    } catch (e) {
      throw CacheException('Failed to update invoice: $e');
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    try {
      final db = await database;
      await db.delete(
        'invoices',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to delete invoice: $e');
    }
  }
}